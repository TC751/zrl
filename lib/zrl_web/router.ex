defmodule ZrlWeb.Router do
  use ZrlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(ZrlWeb.Plugs.SetUser)
    plug(ZrlWeb.Plugs.SessionTimeout, timeout_after_seconds: 10_000)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :session do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  pipeline :app do
    plug(:put_layout, {ZrlWeb.LayoutView, :app})
  end

  pipeline :no_layout do
    plug :put_layout, false
  end

  scope "/", ZrlWeb do
    pipe_through :browser

    get "/create/user", UserController, :new
    post "/create/user", UserController, :create
    get("/system/users", UserController, :index)
    get("/update/user", UserController, :edit)
    post("/update/user", UserController, :update)
    get("/change/user/password", UserController, :new_password)
    post("/change/user/password", UserController, :change_password)
    get("/user/activity/logs", UserController, :user_logs)
    post("/change/user/status", UserController, :change_user_status)
    get("/view/user/activities", UserController, :user_logs)
    get("/repair/users", UserController, :repair_users)
    get("/dashboard", UserController, :dashboard)
    post("/show/user", UserController, :show)
    post("/show/user/signture", UserController, :view_signture)
    post("/admin/assign/loco/driver", LocoDriverController, :create)
    get("/admin/assign/loco/driver", LocoDriverController, :create)
    get("/view/loco/drivers", LocoDriverController, :index)
    post("/change/loco/driver/status", LocoDriverController, :change_status)
    delete("/delete/loco/driver", LocoDriverController, :delete)
  end

  scope "/", ZrlWeb do
    pipe_through([:session])
    get("/forgort/password", UserController, :forgot_password)
    post("/confirmation/token", UserController, :token)
    get("/reset/password", UserController, :reset_password)
    post("/reset/password", UserController, :reset_password)
    get("/token/verification", SessionController, :entrust_token)
    post("/token/verification", SessionController, :confirm_token)
    get("/", SessionController, :new)
    post("/", SessionController, :create)
  end

  scope "/", ZrlWeb do
    pipe_through([:browser, :app])

    get "/view/user/regions", UserRegionController, :index
    get "/new/user/region", UserRegionController, :new
    post "/new/user/region", UserRegionController, :create
    get "/update/user/:id/region", UserRegionController, :edit
    post "/update/user/region", UserRegionController, :update
    # get "/system/user/region", UserRegionController, :index
    delete "/delete/user/region", UserRegionController, :delete
    post "/change/user/region/status", UserRegionController, :change_status
  end

  scope "/", ZrlWeb do
    pipe_through([:browser, :app])

    get("/view/company/infomation", CompanyInfoController, :index)
    get("/new/company/infomation", CompanyInfoController, :new)
    post("/new/company/infomation", CompanyInfoController, :create)
    get("/update/company/infomation", CompanyInfoController, :edit)
    post("/update/company/infomation", CompanyInfoController, :update)
    post("/change/company/infomation/status", CompanyInfoController, :change_status)
    delete("/delete/company/infomation", CompanyInfoController, :delete)
  end

  scope "/", ZrlWeb do
    pipe_through([:browser])
    get("/signout", SessionController, :signout)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZrlWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:zrl, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ZrlWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
