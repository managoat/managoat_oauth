defmodule Managoat.OAuth.FacadeTest do
  use Managoat.OAuth.Case, async: true

  alias Managoat.OAuth

  setup do
    %{config: TestInstance.__managoat_oauth__()}
  end

  test "the direct authorization-code facade carries its default options", %{config: config} do
    subject = subject()
    {verifier, challenge} = pkce()

    assert {:ok, code} = OAuth.authorize(config, subject, request(challenge))
    assert_received {:audit, :authorized, _, []}

    assert {:ok, %{access_token: "tok-" <> ^subject}} =
             OAuth.exchange(config, token_request(code, verifier))

    assert_received {:issue_token, ^subject, %{type: :authorization_code}, []}
  end

  test "the direct device facade approves, denies and polls with default options", %{
    config: config
  } do
    subject = subject()

    assert {:ok, %{device_code: device_code, user_code: user_code}} =
             OAuth.start_device_grant(config)

    assert :ok = OAuth.approve_device_grant(config, user_code, subject)
    assert_received {:audit, :device_approved, _, []}

    assert {:ok, %{access_token: "tok-" <> ^subject}} =
             OAuth.poll_device_grant(config, device_code)

    assert_received {:issue_token, ^subject, %{type: :device}, []}

    assert {:ok, %{device_code: denied_code, user_code: denied_user_code}} =
             OAuth.start_device_grant(config)

    assert :ok = OAuth.deny_device_grant(config, denied_user_code, subject)
    assert_received {:audit, :device_denied, _, []}
    assert {:error, :access_denied} = OAuth.poll_device_grant(config, denied_code)
  end
end
