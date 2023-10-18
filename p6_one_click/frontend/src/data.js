import { UserManager } from "oidc-client-ts";
import { settings } from "./settings";

const userManager = new UserManager(settings);

document.getElementById('login').addEventListener('click', () => {
    userManager.signinRedirect();
});

const cognitoUser = localStorage.getItem("user");
if (cognitoUser) {
    console.log(JSON.stringify(JSON.parse(cognitoUser), null, 2));
}

export function fetchData() {
    // Get the JWT token from localStorage
    const token = localStorage.getItem("pro-jwt");

    // Check if the token is available
    if (!token) {
        console.error("JWT token not found in localStorage.");
        return;
    }

    // Replace 'YOUR_API_ENDPOINT' with the actual API endpoint URL
    const apiUrl = "/api/greeting";

    // Fetch the API data using the token in the Authorization header
    fetch(apiUrl, {
        headers: {
            "Authorization": `${token}`
        }
    })
        .then(response => response.json())
        .then(data => {
            // Display the API response in the outputDiv
            const outputDiv = document.getElementById("outputDiv");
            outputDiv.innerHTML = JSON.stringify(data, null, 2);
        })
        .catch(error => {
            console.error("Error fetching data from the API:", error);
        });
}
document.getElementById('getdata').addEventListener('click', () => {
    fetchData();
});

