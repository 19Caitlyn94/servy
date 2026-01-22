defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing the request, routing to the appropriate handler, and returning the response.
  """

  @pages_path Path.expand("../../pages", __DIR__)
  import Servy.Plugins, only: [rewrite_path: 1, track: 1, log: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc " `Transform the request into a response`"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> track
    |> emojify
    |> format_response
    |> log
  end

  def route(%{path: "/bears", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{path: "/bears/" <> id, method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{path: "/bears/new", method: "GET"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{path: "/about", method: "GET"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  # It's important to note that you wouldn't want to permit this in a production-quality web server. It's a securiy risk that allows for trivial path traversal, and other avenues for exploits. So consider it purely an academic exercise.
  def route(%{path: "/pages/" <> file, method: "GET"} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
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

  def emojify(%{status: 200} = conv) do
    %{conv | resp_body: "✅ " <> conv.resp_body <> " ✅"}
  end

  def emojify(conv), do: conv

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
      500 => "Internal Server Error"
    }[status]
  end
end

# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """
request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
