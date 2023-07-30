
Mox.defmock(Blitz.HttpMock, for: Blitz.Http)
Application.put_env(:blitz, :http, Blitz.HttpMock)
