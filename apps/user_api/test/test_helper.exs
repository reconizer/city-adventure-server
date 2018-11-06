ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Infrastructure.Repository, {:shared, self()})
{:ok, _} = Application.ensure_all_started(:ex_machina)