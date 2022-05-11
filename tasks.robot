*** Settings ***
Documentation       Send e-mail with GMail in a more secure way.
...                 (check devdata/vault.yaml for secrets example)

Library    Collections
Library    OAuth2  # robot internal library
Library    RPA.Browser.Selenium
Library    RPA.Dialogs
Library    RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    imap_server=imap.gmail.com
Library    RPA.Robocorp.Vault


*** Variables ***
${RECIPIENT}    cosmin@robocorp.com


*** Tasks ***
Init OAuth Flow
    ${creds} =    Get Secret    oauth
    ${url} =    Generate Permission Url    ${creds}[client_id]
    Open Available Browser    ${url}

    Add heading       Enter authorization code
    Add text input    code    label=Code
    ${result} =    Run dialog
    ${token} =    Authorize And Get Refresh Token    ${creds}[client_id]
    ...    ${creds}[client_secret]    auth_code=${result.code}
    Set To Dictionary    ${creds}    refresh_token    ${token}
    Set Secret    ${creds}
    
Send Email By Token
    ${creds} =    Get Secret    oauth
    ${password} =    Generate Oauth2 String
    ...    ${creds}[client_id]    ${creds}[client_secret]
    ...    refresh_token=${creds}[refresh_token]    username=${creds}[username]

    Authorize    account=${creds}[username]    password=${password}    is_oauth=${True}
    Send Message    sender=${creds}[username]    recipients=${RECIPIENT}
    ...    subject=E-mail sent through the OAuth2 flow
    ...    body=I hope you find this flow easy to understand and use. (keep the refresh token private at all times)