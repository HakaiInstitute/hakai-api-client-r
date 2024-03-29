% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/client.R
\name{Client}
\alias{Client}
\title{The Hakai API Client Class}
\description{
Class to use to make authenticated API requests for Hakai data
}
\examples{
# Initialize a new client
client <- Client$new()
# Follow authorization prompts to log in

# Retrieve some data. See <https://hakaiinstitute.github.io/hakai-api/> for options.
url <- paste0(client$api_root, "/aco/views/projects?project_year=2020&fields=project_name")
projects_2020 <- client$get(url)

print(projects_2020)
# # A tibble: 20 x 1
#    project_name
#    <chr>
#  1 Fountain FN
#  2 Haig Glacier
#  3 Fraser River - Chimney Creek West William Canyon
#  4 Cruickshank WS
#  ...

## ------------------------------------------------
## Method `Client$new`
## ------------------------------------------------

client <- Client$new()

## ------------------------------------------------
## Method `Client$get`
## ------------------------------------------------

client$get("https://hecate.hakai.org/api/aco/views/projects")

## ------------------------------------------------
## Method `Client$remove_credentials`
## ------------------------------------------------

client$remove_credentials()
}
\section{Public fields}{
\if{html}{\out{<div class="r6-fields">}}
\describe{
\item{\code{api_root}}{The api_root you are logged in to}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-new}{\code{Client$new()}}
\item \href{#method-get}{\code{Client$get()}}
\item \href{#method-remove_credentials}{\code{Client$remove_credentials()}}
\item \href{#method-clone}{\code{Client$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-new"></a>}}
\if{latex}{\out{\hypertarget{method-new}{}}}
\subsection{Method \code{new()}}{
Log into Google to gain credential access to the API
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Client$new(
  api_root = "https://hecate.hakai.org/api",
  login_page = "https://hecate.hakai.org/api-client-login"
)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{api_root}}{Optional API base url to fetch data.
Defaults to "https://hecate.hakai.org/api"}

\item{\code{login_page}}{Optional API login page url to display to user.
Defaults to "https://hecate.hakai.org/api-client-login"}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
A client instance
}
\subsection{Examples}{
\if{html}{\out{<div class="r example copy">}}
\preformatted{client <- Client$new()
}
\if{html}{\out{</div>}}

}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-get"></a>}}
\if{latex}{\out{\hypertarget{method-get}{}}}
\subsection{Method \code{get()}}{
Send a GET request to the API
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Client$get(endpoint_url)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{endpoint_url}}{The full API url to fetch data from}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
A dataframe of the requested data
}
\subsection{Examples}{
\if{html}{\out{<div class="r example copy">}}
\preformatted{client$get("https://hecate.hakai.org/api/aco/views/projects")
}
\if{html}{\out{</div>}}

}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-remove_credentials"></a>}}
\if{latex}{\out{\hypertarget{method-remove_credentials}{}}}
\subsection{Method \code{remove_credentials()}}{
Remove your cached login credentials to logout of the client
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Client$remove_credentials()}\if{html}{\out{</div>}}
}

\subsection{Examples}{
\if{html}{\out{<div class="r example copy">}}
\preformatted{client$remove_credentials()
}
\if{html}{\out{</div>}}

}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-clone"></a>}}
\if{latex}{\out{\hypertarget{method-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Client$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
