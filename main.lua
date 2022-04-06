-- CRLF Injection test
-- trollface security
local socket = require("socket")
local ltn12 = require("ltn12")
local http = require("socket.http")
local ltn12 = require("ltn12")
local url = require("socket.url")

function get_http(url, callback)
  local response = {}
  local body = {}
  local parsed_url = url.parse(url)
  local host = parsed_url.host
  local path = parsed_url.path or "/"
  local port = 80
  if parsed_url.port then
    port = parsed_url.port
  end
  local headers = {
    ["Host"] = host,
    ["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0",
    ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    ["Accept-Language"] = "en-US,en;q=0.5",
    ["Accept-Encoding"] = "gzip, deflate",
    ["Connection"] = "close",
    ["Upgrade-Insecure-Requests"] = "1",
    ["Cache-Control"] = "max-age=0",
  }
  local body_reader = nil
  local request = string.format("GET %s HTTP/1.1\r\n", path)
  for k, v in pairs(headers) do
    request = request .. string.format("%s: %s\r\n", k, v)
  end
  request = request .. "\r\n"
  local sock = socket.tcp()
  sock:settimeout(5)
  local ok, err = sock:connect(host, port)
  if not ok then
    return nil, err
  end
  sock:send(request)
  body_reader = ltn12.source.chain(sock, ltn12.source.empty())
  local _, code, headers = http.request {
    url = url,
    sink = ltn12.sink.table(response),
    headers = headers,
    method = "GET",
    source = body_reader,
  }
  sock:close()
  if code ~= 200 then
    return nil, code
    end
    local body = table.concat(response)
    return body
end


return get_http("") -- url
