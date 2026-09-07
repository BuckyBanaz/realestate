Upload Required Documents ❌ (Missing API)
What it says: "Upload required documents"
Current Status: Not implemented.
Why: There is no API endpoint for this in the Swagger documentation. There is no POST /ChannelPartner/documents or file upload route. Because the API doesn't exist, the Flutter app does not have file_picker installed, nor does it have an upload screen.
Next Step: Ask the backend developer to create a document upload API for the Channel Partner (accepting multipart/form-data). Once they add it, we can build the UI for it in 10 minutes.
2. Manage Profile (Updating) ⚠️ (Missing API)
What it says: "Login with Number and manage their profile"
Current Status: You can view the profile, but you cannot update it.
Why: The backend only provides GET /ChannelPartner/profile. There is no PATCH or PUT route for a Channel Partner to actually edit their name, email, or photo.
Next Step: If you want them to be able to edit their profile, ask the backend dev for an update profile route.
3. Track Lead Status Categories ⚠️ (Mismatch)
What it says: Track lead status (Pending, Approved, Rejected, Converted)
Current Status: Handled, but using different words!
Why: The backend actually expects new, seen, contacted, proposal, negotiation, closed instead of the words in the doc. I have already wired the Flutter app to use the actual backend words, so the app will work perfectly, but the doc is technically outdated here.