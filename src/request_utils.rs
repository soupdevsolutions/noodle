use lambda_http::{Body, Request, RequestExt};
use serde::de::DeserializeOwned;

#[tracing::instrument]
pub fn get_query_string_parameter(event: &Request, key: &str) -> Option<String> {
    event
        .query_string_parameters()
        .first(key)
        .map(|v| v.to_string())
}

#[tracing::instrument]
pub fn get_body<T>(event: &Request) -> Result<T, String>
where
    T: DeserializeOwned,
{
    let body = match event.body() {
        Body::Binary(body) => std::str::from_utf8(body).map_err(|e| e.to_string())?,
        _ => return Err("Invalid body".into()),
    };

    let result: T = serde_html_form::from_str(body).map_err(|e| e.to_string())?;
    Ok(result)
}

#[tracing::instrument]
pub fn get_header(event: &Request, header: &str) -> Result<String, String> {
    let header = event
        .headers()
        .get(header)
        .ok_or_else(|| format!("Missing header: {}", header))?
        .to_str()
        .map_err(|e| e.to_string())?
        .to_string();
    Ok(header)
}
