defmodule ScannerFw.JPEGStreamer do
  import Plug.Conn

  @behaviour Plug
  @boundary "w58EW1cEpjzydSCq"

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("Age", "0")
    |> put_resp_header("Cache-Control", "no-cache, private")
    |> put_resp_header("Pragma", "no-cache")
    |> put_resp_header("Content-Type", "multipart/x-mixed-replace; boundary=#{@boundary}")
    |> send_chunked(200)
    |> send_pictures
  end

  defp send_pictures(conn) do
    conn
    |> send_picture()
    |> send_pictures()
  end

  defp send_picture(conn) do
    jpg = Scanner.Camera.next_frame()
    size = byte_size(jpg)
    header = "------#{@boundary}\r\nContent-Type: image/jpeg\r\nContent-length: #{size}\r\n\r\n"
    footer = "\r\n"

    with {:ok, conn} <- chunk(conn, header),
         {:ok, conn} <- chunk(conn, jpg),
         {:ok, conn} <- chunk(conn, footer),
         do: conn
  end
end
