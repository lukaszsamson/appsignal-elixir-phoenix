defmodule PhoenixWeb.Router do
  use Phoenix.Router

  get("/", PhoenixWeb.Controller, :index)
  get("/exception", PhoenixWeb.Controller, :exception)
end

defmodule PhoenixWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_web
  use Appsignal.Phoenix

  plug(PhoenixWeb.Router)
end

defmodule PhoenixWeb.Controller do
  use Phoenix.Controller, namespace: PhoenixWeb
  import Plug.Conn

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "Welcome to Phoenix!")
  end

  def exception(conn, _params) do
    raise "Exception!"
  end
end

defmodule PhoenixWeb.ErrorView do
  import Plug.Conn

  def render(_layout, %{reason: reason}) do
    inspect(reason)
  end
end