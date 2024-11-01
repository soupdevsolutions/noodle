use askama::Template;

use crate::payment::PaymentDTO;

#[derive(Template)]
#[template(path = "donation_list.html")]
pub struct DonationsListTemplate {
    pub donations: Vec<PaymentDTO>,
}
