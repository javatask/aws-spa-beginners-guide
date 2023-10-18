export const settings = {
    authority: 'https://cognito-idp.eu-central-1.amazonaws.com/eu-central-1_xxxx',
    client_id: 'xxxxx',
    redirect_uri: 'https://xxxxx.cloudfront.net/callback.html',
    response_type: 'code',
    scope: 'openid',
    revokeTokenTypes: ["refresh_token"],
    automaticSilentRenew: false,
};