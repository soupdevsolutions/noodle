use askama::Template;
use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::Client;
use lambda_http::{service_fn, Body, Error, Request, Response};
use noodle::{
    payment::Payment, payments_repository::PaymentsRepository,
    request_utils::get_query_string_parameter, templates::DonationsListTemplate,
};
use serde::Serialize;

#[derive(Serialize)]
pub struct GetPaymentsResponse {
    pub payments: Vec<Payment>,
}

#[tracing::instrument(skip(payments_repository))]
async fn handler(
    payments_repository: &PaymentsRepository,
    event: Request,
) -> Result<Response<Body>, Error> {
    tracing::info!("Received event: {:?}", event);

    let count = get_query_string_parameter(&event, "count");
    let count = match count {
        Some(value) => value.parse::<i32>().unwrap(),
        None => 10,
    };

    let payments = payments_repository.get_payments(count).await?;
    let payments = payments
        .into_iter()
        .map(|payment| payment.into())
        .collect::<Vec<_>>();

    let template = DonationsListTemplate {
        donations: payments,
    };
    let data = template.render()?;

    Ok(Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(data.into())
        .map_err(Box::new)?)
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

    lambda_http::run(service_fn(|request| handler(&payments_repository, request))).await?;
    Ok(())
}
