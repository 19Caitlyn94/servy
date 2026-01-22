defmodule Servy.Plugins do
  def track(%{status: 404, path: path} = conv) do
    IO.puts("Not found: #{path}")
    conv
  end
  def track(conv), do: conv

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  @spec log(any()) :: any()
  def log(conv), do: IO.inspect(conv)

end
