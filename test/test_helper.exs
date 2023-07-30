{:ok, _} = Application.ensure_all_started(:mox)
{:ok, _} = Application.ensure_all_started(:ex_machina)
Faker.start()

Mox.defmock(Blitz.HttpMock, for: Blitz.Http)
Application.put_env(:blitz, :http, Blitz.HttpMock)

ExUnit.start()
