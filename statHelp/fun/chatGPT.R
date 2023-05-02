#' Call the OpenAI API
#'
#' This function sends a request to the OpenAI API with the specified prompt, API key, and model.
#'
#' @param prompt The text prompt to be completed by the OpenAI API.
#' @param api_key Your OpenAI API key.
#' @param model The OpenAI model to be used. Defaults to "text-davinci-002".
#'
#' @return A list containing the API response.
#' @export
#'
#' @examples
#' api_key <- "your-api-key"
#' prompt <- "Once upon a time..."
#' response <- call_openai_api(prompt, api_key)
#' print(response)
call_openai_api <- function(prompt, api_key, model = "text-davinci-002") {
  # Load required packages
  lapply(c("httr", "jsonlite", "tidyverse"), require, character.only = TRUE)
  openai_api_key <- Sys.getenv("OPENAI_KEY")
  api_url <- paste0("<https://api.openai.com/v1/engines/>", model, "/completions")
  headers <- add_headers(
    "Content-Type" = "application/json",
    "Authorization" = paste("Bearer", api_key)
  )
  body <- toJSON(
    list(
      prompt = prompt,
      max_tokens = 100,
      n = 1,
      temperature = 0.7
    ),
    auto_unbox = TRUE
  )
  response <- POST(api_url, headers, body = body)
  if (http_status(response)$category == "Success") {
    response_parsed <- fromJSON(content(response, as = "text", encoding = "UTF-8"))
    return(response_parsed$choices)
  } else {
    stop("Error calling OpenAI API: ", content(response, as = "text", encoding = "UTF-8"))
  }
}
createPrompt <- function(){
  
}