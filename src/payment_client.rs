use crate::{
    environment::{DOMAIN, STRIPE_SECRET_KEY},
    payment::Payment,
};
use stripe::{
    CheckoutSession, CheckoutSessionMode, Client, CreateCheckoutSession,
    CreateCheckoutSessionLineItems, CreateCheckoutSessionLineItemsPriceData,
    CreateCheckoutSessionLineItemsPriceDataProductData, CreateCheckoutSessionPaymentIntentData,
    Currency, Metadata,
};

pub struct PaymentClient {
    stripe_client: stripe::Client,
    success_url: String,
}

impl Default for PaymentClient {
    fn default() -> Self {
        Self::new()
    }
}

impl PaymentClient {
    pub fn new() -> Self {
        let secret_key = std::env::var(STRIPE_SECRET_KEY)
            .unwrap_or_else(|_| format!("{} variable not set", STRIPE_SECRET_KEY));
        let domain =
            std::env::var(DOMAIN).unwrap_or_else(|_| format!("{} variable not set", DOMAIN));
        Self {
            stripe_client: Client::new(secret_key),
            success_url: domain,
        }
    }

    #[tracing::instrument(skip(self))]
    pub async fn initiate_payment(&self, payment: &Payment) -> Result<String, String> {
        // Create the Stripe Checkout Session parameters
        let mut create_session_params = CreateCheckoutSession::new();
        create_session_params.line_items = Some(vec![CreateCheckoutSessionLineItems {
            price_data: Some(CreateCheckoutSessionLineItemsPriceData {
                currency: Currency::USD,
                product_data: Some(CreateCheckoutSessionLineItemsPriceDataProductData {
                    name: format!("Payment from {}", payment.sender),
                    ..Default::default()
                }),
                unit_amount: Some(payment.amount),
                ..Default::default()
            }),
            quantity: Some(1),
            ..Default::default()
        }]);
        // Set the mode to payment
        create_session_params.mode = Some(CheckoutSessionMode::Payment);
        create_session_params.success_url = Some(self.success_url.as_str());

        // Add the payment id to the metadata
        let mut metadata = Metadata::new();
        metadata.insert("payment_id".to_string(), payment.id.to_string());
        create_session_params.payment_intent_data = Some(CreateCheckoutSessionPaymentIntentData {
            metadata: Some(metadata),
            ..Default::default()
        });

        // Create the Stripe Checkout Session
        let session = CheckoutSession::create(&self.stripe_client, create_session_params)
            .await
            .map_err(|e| e.to_string())?;

        // safe to unwrap, as this is an active session that we just created
        Ok(session.url.unwrap())
    }
}
