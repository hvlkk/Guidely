const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

// recommend this tour based on, how close the user is to the tour location
// and how much the user likes the tour category
async function getRecommendationScore(userData, tourData) {
  const meetingLocationLat = tourData.tourDetails.waypoints[0].latitude;
  console.log("Meeting location lat: ", meetingLocationLat);
  const meetingLocationLng = tourData.tourDetails.waypoints[0].longitude;
  console.log("Meeting location lng: ", meetingLocationLng);

  try {
    const userLocation = await getUserLocation();
    const userLat = userLocation.latitude;
    const userLng = userLocation.longitude;
    console.log("User location:", userLocation);

    const distanceInKM = haversineDistance(
      { latitude: userLat, longitude: userLng },
      { latitude: meetingLocationLat, longitude: meetingLocationLng }
    );

    const distanceScore = calculateDistanceScore(distanceInKM);
    console.log("Distance score:", distanceScore);

    // for every tour in user's booked tours pou tou arese with star reviews, me kalo score
    // briskoume poso moiazei to sugkekrimeno tour pou ftiajame me ta parapanw pou exoyn kalo score ->

    // lista1 = [10000, 20, 30000] -> poso tou arese to kathe tour apo ta booked (megalo skor, tou arese polu)
    // lista2 = [10000, 10, 10] -> poso similar einai to kathe tour apo ta booked me to neo (me bash ta waypoints kai to activities)

    // 10000 * 1/10000 = 1, 30000/ 10 = 3000

    // similarity with preferred categorires
    // const userCategories = userData.preferredTourCategories;
    // const tourActivities = tourData.tourDetails.activities;

    const totalScore = distanceScore;
    return totalScore;
  } catch (error) {
    console.error("Error getting location:", error);
    return 0; // Return a default score in case of error
  }
}

function calculateDistanceScore(distance, decayFactor = 20) {
  return Math.exp(-distance / decayFactor);
}

function haversineDistance(coords1, coords2) {
  function toRad(x) {
    return (x * Math.PI) / 180;
  }

  const R = 6371; // Radius of the Earth in km
  const dLat = toRad(coords2.latitude - coords1.latitude);
  const dLon = toRad(coords2.longitude - coords1.longitude);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(coords1.latitude)) *
      Math.cos(toRad(coords2.latitude)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function getUserLocation() {
  return new Promise((resolve, reject) => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          resolve({ latitude, longitude });
        },
        (error) => {
          reject(error);
        }
      );
    } else {
      reject(new Error("Geolocation is not supported by this browser."));
    }
  });
}

module.exports = {
  getRecommendationScore,
};
