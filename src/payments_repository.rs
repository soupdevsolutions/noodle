use aws_sdk_dynamodb::{types::AttributeValue, Client};

use crate::payment::{Payment, PaymentStatus, CREATED_AT_INDEX};

pub const PAYMENTS_TABLE: &str = "PAYMENTS_TABLE_NAME";
pub const PAYMENTS_CREATED_AT_INDEX: &str = "PAYMENTS_CREATED_AT_INDEX";

#[derive(Debug)]
pub struct PaymentsRepository {
    client: Client,
    table_name: String,
    created_at_index_name: String,
}

impl PaymentsRepository {
    pub fn new(client: Client) -> Self {
        let table_name = std::env::var(PAYMENTS_TABLE)
            .unwrap_or_else(|_| panic!("{} variable not set", PAYMENTS_TABLE));
        let created_at_index_name = std::env::var(PAYMENTS_CREATED_AT_INDEX)
            .unwrap_or_else(|_| panic!("{} variable not set", PAYMENTS_CREATED_AT_INDEX));

        Self {
            client,
            table_name,
            created_at_index_name,
        }
    }

    #[tracing::instrument]
    pub async fn get_payments(&self, count: i32) -> Result<Vec<Payment>, String> {
        let request = self
            .client
            .query()
            .table_name(&self.table_name)
            .index_name(&self.created_at_index_name)
            .key_condition_expression("#cai = :cai")
            .expression_attribute_names("#cai", "created_at_index")
            .expression_attribute_values(":cai", AttributeValue::S(CREATED_AT_INDEX.to_string()))
            .filter_expression("#status = :status")
            .expression_attribute_names("#status", "status")
            .expression_attribute_values(
                ":status",
                AttributeValue::N((PaymentStatus::Completed as i8).to_string()),
            )
            .limit(count)
            .scan_index_forward(false)
            .send()
            .await
            .map_err(|e| e.to_string())?;
        tracing::info!("Query response: {:?}", request);

        let items = request.items.unwrap_or_default();
        tracing::info!("Items: {:?}", items);

        let payments = items
            .iter()
            .map(|item| {
                let id = item.get("id").unwrap().as_s().unwrap().to_string();
                let amount = item.get("amount").unwrap().as_n().unwrap().parse().unwrap();
                let sender = item.get("sender").unwrap().as_s().unwrap().to_string();
                let status: u8 = item.get("status").unwrap().as_n().unwrap().parse().unwrap();
                let message = item.get("message").unwrap().as_s().unwrap().to_string();
                let created_at = item
                    .get("created_at")
                    .unwrap()
                    .as_n()
                    .unwrap()
                    .parse()
                    .unwrap();

                let status = match status {
                    1 => PaymentStatus::Pending,
                    2 => PaymentStatus::Failed,
                    3 => PaymentStatus::Completed,
                    _ => PaymentStatus::Pending,
                };

                Payment {
                    id,
                    amount,
                    sender,
                    status,
                    message,
                    created_at,
                    created_at_index: "".to_string(),
                }
            })
            .collect();
        tracing::info!("Payments: {:?}", payments);

        Ok(payments)
    }

    #[tracing::instrument]
    pub async fn insert_payment(&self, payment: Payment) -> Result<(), String> {
        let id = AttributeValue::S(payment.id);
        let amount = AttributeValue::N(payment.amount.to_string());
        let sender = AttributeValue::S(payment.sender);
        let status = AttributeValue::N((payment.status as i8).to_string());
        let created_at = AttributeValue::N(payment.created_at.to_string());
        let message = AttributeValue::S(payment.message);

        self.client
            .put_item()
            .table_name(&self.table_name)
            .item("id", id)
            .item("amount", amount)
            .item("sender", sender)
            .item("status", status)
            .item("message", message)
            .item("created_at", created_at)
            .item(
                "created_at_index",
                AttributeValue::S(CREATED_AT_INDEX.to_string()),
            )
            .send()
            .await
            .map_err(|e| e.to_string())?;

        Ok(())
    }

    #[tracing::instrument]
    pub async fn update_payment_status(
        &self,
        payment_id: &str,
        new_status: PaymentStatus,
    ) -> Result<(), String> {
        let id = AttributeValue::S(String::from(payment_id));
        let status = AttributeValue::N((new_status as i8).to_string());

        let _request = self
            .client
            .update_item()
            .table_name(&self.table_name)
            .key("id", id)
            .update_expression("SET #status = :status")
            .expression_attribute_names("#status", "status")
            .expression_attribute_values(":status", status)
            .send()
            .await
            .map_err(|e| e.to_string())?;

        Ok(())
    }
}
