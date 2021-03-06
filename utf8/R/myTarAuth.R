myTarAuth <-
  function(login              = NULL,
           grant_type         = "client_credentials", 
           client_id          = getOption('rmytarget.client_id'),
           client_secret      = getOption("rmytarget.client_secret"),
           agency_client_name = NULL,
           code_grant         = getOption("rmytarget.code_grant_auth"),
           token_path         = getwd()){
    
   
    if (code_grant == TRUE) {

      # try load token
      if(file.exists(paste0(token_path, "\\", login, ".mytar.Auth.RData"))) {
        
          message("Load token from ", paste0(token_path, "/", login, ".mytar.Auth.RData"))
          load(paste0(token_path, "\\", login, ".mytar.Auth.RData"))
            if (!is.null(parse_token$error)) {
              stop(parse_token$error,": ", parse_token$error_description)
            }
          # check expire token, and update him
        if ( !is.null(parse_token$expires_in) ) {
          if ( as.numeric(parse_token$expire_at - Sys.time(), units = "mins") < 30 ) {
              message("Token expire after ", round(as.numeric(parse_token$expire_at - Sys.time(), units = "mins"), 0), " mins")
              message("Auto refreshing token")

              parse_token <- myTarRefreshToken(old_auth = parse_token, client_id = client_id, client_secret = client_secret)

              if (! is.null(parse_token$error)) {
                stop(parse_token$error,": ", parse_token$error_description)
              }

              parse_token$expire_at <- Sys.time() + as.numeric(parse_token$expires_in, units = "secs") 
              save(parse_token, file = paste0(token_path, "/", login, ".mytar.Auth.RData"))
              message("Token saved at ", paste0(token_path, "/", login, ".mytar.Auth.RData"))
              return(parse_token)
            }
          } else {
            # return token if he live more than 60 mins
            return(parse_token)
          }
      }
      
      # create state token
      min_l <- letters[runif(n = 10, min = 1, max = length(letters))]
      up_l  <- LETTERS[runif(n = 10, min = 1, max = length(LETTERS))]
      nums  <- as.character(round(runif(20, min = 0, max = 9), 0))
      state <- paste0(sample(c(min_l, up_l, nums), size = 14, replace = T), collapse = "")
      
      # brows
      browseURL(str_interp("${getOption('rmytarget.url')}oauth2/authorize?response_type=code&client_id=${client_id}&state=${state}&scope=read_payments,read_ads,read_clients,read_manager_clients"))
      code <- readline(prompt = "Enter code from browser: ")
       
      raw_token <- POST(url = str_interp("${getOption('rmytarget.url')}api/v2/oauth2/token.json"),
                        body = list(grant_type = "authorization_code", code = code, client_id = client_id, permanent = "true"), 
                        encode = "form")
      parse_token <- content(raw_token, as = "parsed", type = "application/json")
      parse_token$expire_at <- Sys.time() + as.numeric(parse_token$expires_in, units = "secs")
      
      # savetoken
      if ( !is.null(parse_token$access_token) ) {
        save(parse_token, file = paste0(token_path, "/", login, ".mytar.Auth.RData"))
        message("Token saved at ", paste0(token_path, "/", login, ".mytar.Auth.RData"))
      }

      return(parse_token)
    } else {
       
      query_body <- paste0("grant_type=", grant_type,
                           "&client_id=", client_id,
                           "&client_secret=", client_secret,
                           ifelse(grant_type == "agency_client_credentials", paste0("&agency_client_name=",agency_client_name),""))
      
      mtAuth <- POST(str_interp("${getOption('rmytarget.url')}token.json"),body = query_body, content_type(type = "application/x-www-form-urlencoded"))
      
      stop_for_status(mtAuth)
      
      mtAuth <- content(mtAuth, "parsed", "application/json")
      return(mtAuth)
     }
    
  }
