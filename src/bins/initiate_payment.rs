use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::Client;
use lambda_http::{service_fn, Body, Error, Request, Response};
use noodle::{
    payment::{Payment, PaymentStatus},
    payment_client::PaymentClient,
    payments_repository::PaymentsRepository,
    request_utils::get_body,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct InitiatePaymentRequest {
    pub amount: f32,
    pub sender: String,
    pub message: String,
}

#[derive(Serialize)]
pub struct InitiatePaymentResponse {
    pub redirect_url: String,
}

#[tracing::instrument(skip(payments_repository, payment_client))]
async fn handler(
    payments_repository: &PaymentsRepository,
    payment_client: &PaymentClient,
    event: Request,
) -> Result<Response<Body>, Error> {
    tracing::info!("Received event: {:?}", event);

    // Get the payment request from the event
    let payment_request: InitiatePaymentRequest = get_body(&event)?;

    let amount = (payment_request.amount * 100.0).round() as i64;

    // Create the Payment object with a unique id
    let payment = Payment::new(
        Uuid::new_v4().to_string(),
        amount,
        payment_request.sender,
        payment_request.message,
        PaymentStatus::Pending,
    );

    // Get the redirect URL from the `initiate payment` process
    let redirect_url = payment_client.initiate_payment(&payment).await?;
    // Get the singleton instance of the payments repository
    // Save the data in DynamoDB
    payments_repository.insert_payment(payment).await?;

    // Return the redirect URI
    let response = InitiatePaymentResponse { redirect_url };

    Ok(Response::builder()
        .status(200)
        .header("HX-Redirect", response.redirect_url)
        .body(Body::Empty)
        .expect("Failed to render response"))
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .json()
        .with_max_level(tracing::Level::INFO)
        .with_current_span(false)
        .with_ansi(false)
        .without_time()
        .with_target(false)
        .init();

    let aws_config = aws_config::load_defaults(BehaviorVersion::latest()).await;
    let dynamodb_client = Client::new(&aws_config);

    let payments_repository = PaymentsRepository::new(dynamodb_client);
    let payment_client = PaymentClient::new();

    lambda_http::run(service_fn(|request| {
        handler(&payments_repository, &payment_client, request)
    }))
    .await?;
    Ok(())
}
