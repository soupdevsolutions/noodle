use chrono::DateTime;
use serde::{Deserialize, Serialize};

pub const CREATED_AT_INDEX: &str = "CAI";

#[derive(Debug, Serialize, Deserialize)]
pub enum PaymentStatus {
    Pending = 1,
    Failed = 2,
    Completed = 3,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Payment {
    pub id: String,
    pub amount: i64,
    pub sender: String,
    pub message: String,
    pub status: PaymentStatus,
    pub created_at: u128,
    // used for creating the GSI
    pub created_at_index: String,
}

impl Payment {
    pub fn new(
        id: String,
        amount: i64,
        sender: String,
        message: String,
        status: PaymentStatus,
    ) -> Self {
        Self {
            id,
            amount,
            sender,
            message,
            status,
            created_at: std::time::UNIX_EPOCH.elapsed().unwrap().as_millis(),
            created_at_index: CREATED_AT_INDEX.to_string(),
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct PaymentDTO {
    pub amount: f32,
    pub sender: String,
    pub message: String,
    pub status: PaymentStatus,
    pub created_at: String,
}

impl From<Payment> for PaymentDTO {
    fn from(value: Payment) -> Self {
        let date_time = DateTime::from_timestamp(value.created_at as i64 / 1000, 0).unwrap();
        return Self {
            amount: value.amount as f32 / 100_f32,
            sender: value.sender,
            message: value.message,
            status: value.status,
            created_at: date_time.format("%d/%m/%Y %H:%M").to_string(),
        };
    }
}
