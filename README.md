# Feelingsmotron

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Environment Variables

* SECRET_KEY_BASE - Used to generate session cookies. To generate your own:
```elixir
:crypto.strong_rand_bytes(64) |> Base.encode64 |> binary_part(0, 64)
```
* DATABASE_URL - The URL to your postgres database instance on Heroku
* PG_USER - The postgres username used in the development and test environments
* PG_PASSWORD - The postgres password used in the development and test environments

### JWT Key Configuration

Feelingsmotron uses the ES512 algorithm to generate JSON Web Tokens. You will need to generate a key and set the appropriate environment variables.

To generate a key do the following from the root pairmotron directory:

```elixir
iex -S mix

iex> JOSE.JWK.generate_key({:ec, "P-521"}) |> JOSE.JWK.to_map
{%{kty: :jose_jwk_kty_ec},
 %{"crv" => "P-521",
   "d" => "Ae-wdbGhjfpxapevgJDAxaiGHmKYoyWnYDLeAb9jALSBNBzkyelSL-FUHcdFw1B7V2FvPy3YaHEkrVqwPwBwNvLP",
   "kty" => "EC",
   "x" => "AWFw34kJJaT8Lwew8IG4LcDDr8sMcURn4PhUWMBiMW5vGGonteVvZQAVdW652GFOY9z1nlhymKYXBwNy3PHlz9Z_",
   "y" => "APLY5Rww4oI1fhUI7JrIkmHPymzgpGOKsNXHhxoMJDycdoQPWfaimoOX-afOHoJiGWwh2m_EbTSC-4lC4Cz0uzPk"}}
```

And then set the following environment variables:
* GUARDIAN_JWK_ES512_D - The "d" value of the key generated above.
* GUARDIAN_JWK_ES512_X - The "x" value of the key generated above.
* GUARDIAN_JWK_ES512_Y - The "y" value of the key generated above.
