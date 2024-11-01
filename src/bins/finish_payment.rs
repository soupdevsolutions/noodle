use aws_config::BehaviorVersion;
use aws_sdk_dynamodb::Client;
use lambda_http::{service_fn, Body, Error, Request, Response};
use noodle::{
    environment::STRIPE_WEBHOOK_SECRET, payment::PaymentStatus,
    payments_repository::PaymentsRepository, request_utils::get_header,
};
use stripe::{ChargeStatus, EventObject, Webhook};

const SIGNATURE_HEADER_KEY: &str = "Stripe-Signature";

async fn handler(
    payments_repository: &PaymentsRepository,
    event: Request,
) -> Result<Response<Body>, Error> {
    let signature = get_header(&event, SIGNATURE_HEADER_KEY)?;
    let webhook_secret = std::env::var(STRIPE_WEBHOOK_SECRET).map_err(|e| e.to_string())?;

    // getting the event body as a string
    let event_body = match event.body() {
        Body::Text(s) => s,
        _ => {
            tracing::error!("Error getting event body");
            return Err(Error::from("Error getting event body"));
        }
    };

    // constructing the event to validate the incoming data
    let webhook_event =
        Webhook::construct_event(event_body, &signature, &webhook_secret).map_err(|e| {
            tracing::error!("Error constructing webhook event: {e}");
            Error::from(format!("Error constructing webhook event: {e}"))
        })?;

    // confirming that the event is a charge.
    let charge = match webhook_event.data.object {
        EventObject::Charge(charge) => charge,
        _ => {
            tracing::error!("The event is not a charge");
            return Err(Error::from("The event is not a charge"));
        }
    };

    // getting the payment id from the event's metadata
    let payment_id = charge.metadata.get("payment_id").unwrap().to_string();

    // matching our payment status to Stripe's charge status
    let payment_status = match charge.status {
        ChargeStatus::Succeeded => PaymentStatus::Completed,
        ChargeStatus::Failed => PaymentStatus::Failed,
        _ => {
            tracing::error!("Wrong payment status received");
            return Err(Error::from("Wrong payment status received"));
        }
    };

    // updatig the payment status in the database
    payments_repository
        .update_payment_status(&payment_id, payment_status)
        .await?;

    Ok(Response::new(Body::from(())))
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
