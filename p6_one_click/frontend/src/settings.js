export const settings = {
    authority: 'https://cognito-idp.eu-central-1.amazonaws.com/eu-central-1_xxxxxxx',
    client_id: 'xxxxxxxxxxxxxxxxx',
    redirect_uri: 'https://xxxxxxxx.cloudfront.net/callback.html',
    response_type: 'code',
    scope: 'openid',
    revokeTokenTypes: ["refresh_token"],
    automaticSilentRenew: false,
};
