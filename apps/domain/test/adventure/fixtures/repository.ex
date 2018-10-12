defmodule Domain.Adventure.Fixtures.Repository do
  #  use ExMachina.Ecto, repo: Infrastructure.Repository
  use Infrastructure.Repository.Models
  use ExMachina.Ecto, repo: Infrastructure.Repository

  def user_factory do
    %Models.User{
      nick: Faker.Internet.user_name(),
      email: Faker.Internet.free_email(),
      password_digest: Comeonin.Bcrypt.hashpwsalt("1234")
    }
  end

  def adventure_factory do
    %Models.Adventure{
      description: Faker.Lorem.Shakespeare.hamlet(),
      code: "1234",
      language: "PL",
      difficulty_level: 2,
      estimated_time: "09:00:00",
      name: Faker.Name.name,
      published: true,
      show: false
    }
  end

  def point_factory do
    %Models.Point{
      show: false,
      radius: 5,
      adventure: build(:adventure),
      position: %Geo.Point{coordinates: {18.602801, 53.008519}, srid: 4326}
    }
  end

  def clue_factory do
    %Models.Clue{
      type: "text",
      tip: false,
      description: Faker.Lorem.Shakespeare.hamlet(),
      point_id: build(:point)
    }
  end

  def user_adventure_factory do
    %{
      adventure: build(:adventure),
      user: build(:user)
    }
  end

  def user_point_factory do
    %{
      point: build(:point),
      user: build(:user)
    }
  end

end