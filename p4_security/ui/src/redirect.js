import { OidcClient } from "oidc-client-ts";
import { settings } from "./settings";

console.log(settings);
const userManager = new OidcClient(settings);
console.log(userManager);
userManager.processSigninResponse(window.location.href).then(function (user) {
    if (user) {
        console.log(user);
        localStorage.setItem("user", JSON.stringify(user));
        localStorage.setItem("pro-jwt", user.id_token);

        window.location.href = '/';
    } else {
        console.error('No user found');
    }
}).catch(function (err) {
    console.error(err);
});