defmodule NotFoundError do
  defexception message: "not found"

  def exception([message: message]) do
    %__MODULE__{message: message}
  end

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end
end
