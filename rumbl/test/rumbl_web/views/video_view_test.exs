defmodule RumblWeb.VideoViewTest do
  use RumblWeb.ConnCase, async: true

  import Phoenix.View

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.{Video, Category}
  alias RumblWeb.VideoView

  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{id: "1", title: "dogs"},
      %Video{id: "2", title: "cats"}
    ]

    content =
      render_to_string(
        VideoView,
        "index.html",
        conn: conn,
        videos: videos
      )

    assert String.contains?(content, "Listing Videos")

    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders news.html", %{conn: conn} do
    owner = %Rumbl.Accounts.User{}

    changeset = Multimedia.change_video(%Video{})
    categories = [%Category{id: 123, name: "cats"}]

    content =
      render_to_string(
        VideoView,
        "new.html",
        conn: conn,
        changeset: changeset,
        categories: categories
      )

    assert String.contains?(content, "New Video")
  end
end
