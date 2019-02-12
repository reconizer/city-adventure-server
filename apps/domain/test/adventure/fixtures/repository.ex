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

  def creator_factory do
    %Models.Creator{
      name: Faker.Name.name(),
      description: Faker.Lorem.Shakespeare.hamlet(),
      approved: true,
      address1: Faker.Address.En.street_address(),
      city: Faker.Address.En.city(),
      country: Faker.Address.En.country(),
      email: Faker.Internet.free_email(),
      password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
      zip_code: Faker.Address.En.zip_code()
    }
  end

  def adventure_factory do
    %Models.Adventure{
      description: Faker.Lorem.Shakespeare.hamlet(),
      code: "1234",
      language: "PL",
      difficulty_level: 2,
      min_time: "02:00:00",
      max_time: "06:00:00",
      name: Faker.Name.name(),
      published: true,
      show: false,
      creator: build(:creator)
    }
  end

  def adventure_rating_factory do
    %Models.AdventureRating{
      user: build(:user),
      adventure: build(:adventure),
      rating: Enum.random(1..5)
    }
  end

  def point_factory do
    %Models.Point{
      show: false,
      radius: 5,
      adventure: build(:adventure),
      parent_point_id: nil,
      position: %Geo.Point{coordinates: {18.602801, 53.008519}, srid: 4326}
    }
  end

  def clue_factory do
    %Models.Clue{
      type: "text",
      tip: false,
      description: Faker.Lorem.Shakespeare.hamlet(),
      point: build(:point)
    }
  end

  def user_adventure_factory do
    %Models.UserAdventure{
      adventure: build(:adventure),
      user: build(:user)
    }
  end

  def user_point_factory do
    %Models.UserPoint{
      point: build(:point),
      user: build(:user)
    }
  end

  def ranking_factory do
    %Models.Ranking{
      adventure: build(:adventure),
      user: build(:user),
      completion_time: 6700
    }
  end
end
