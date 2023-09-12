defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.{Category, Video}

  describe "categories" do
    test "list_alphabetical_categories/0" do
      for name <- ~w(Drama Action Comedy) do
        Multimedia.create_category!(name)
      end

      alpha_names =
        for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
          name
        end

      assert alpha_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    @valid_attrs %{description: "desc", title: "title", url: "https://local"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    setup do
      {:ok, owner: user_fixture()}
    end

    test "list_videos/0, returns all videos", %{owner: owner} do
      %Video{id: id_1} = video_fixture(owner)
      assert [%Video{id: ^id_1}] = Multimedia.list_videos()

      %Video{id: id_2} = video_fixture(owner)
      assert [%Video{id: ^id_1}, %Video{id: ^id_2}] = Multimedia.list_videos()
    end

    test "get_video!/1, returns the video with given id", %{owner: owner} do
      %Video{id: id_1} = video_fixture(owner)
      assert %Video{id: ^id_1} = Multimedia.get_video!(id_1)
    end

    test "create_video/2, with valid data creates a video", %{owner: owner} do
      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, @valid_attrs)

      assert video.description == "desc"
      assert video.title == "title"
      assert video.url == "https://local"
    end

    test "create_video/2, with invalid data returns error changeset", %{owner: owner} do
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2, with valid data updates the video", %{owner: owner} do
      video = video_fixture(owner)

      assert {:ok, %Video{} = video} = Multimedia.update_video(video, %{title: "updated title"})
      assert video.title == "updated title"
    end

    test "update_video/2, with invalid data returns error changeset", %{owner: owner} do
      %Video{id: id} = video = video_fixture(owner)

      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1, deletes the video", %{owner: owner} do
      video = video_fixture(owner)
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert Multimedia.list_videos() == []
    end

    test "change_video/1, returns a video changeser", %{owner: owner} do
      video = video_fixture(owner)
      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end
end
