defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def rewrite_path(%{path: "/wildthings"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  @spec log(any()) :: any()
  def log(conv), do: IO.inspect(conv)

  @spec parse(binary()) :: %{method: binary(), path: binary(), resp_body: <<>>}
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> hd
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end


  def route(%{path: "/bears", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{path: "/bears/" <> id, method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{path: "/wildthings", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{path: "/bigfoot", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bigfoot is afoot!"}
  end

  def route(%{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id} deleted"}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here"}
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts("Not found: #{path}")
    conv
  end

  def track(conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{format_status(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp format_status(status) do
    %{
      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      204 => "No Content",
      302 => "Found",
      304 => "Not Modified",
      400 => "Bad Request",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error",
    }[status]
  end
end

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
