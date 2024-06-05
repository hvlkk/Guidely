const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

// Function to fetch all the tours objects that the user has booked
async function fetchUserBookedTours(userBookings) {
  const tours = [];
  for (let i = 0; i < userBookings.length; i++) {
    const tourId = userBookings[i];
    const tour = await admin.firestore().collection("tours").doc(tourId).get();
    tours.push(tour.data());
  }
  return tours;
}

// Function to create a hashmap of areas -> number of booked tours in that area
function createAreasMap(tours) {
  const areas = {};
  for (let i = 0; i < tours.length; i++) {
    const tour = tours[i];
    const area = tour.country;
    if (areas[area]) {
      areas[area] += 1;
    } else {
      areas[area] = 1;
    }
  }
  return areas;
}

// Function to find the area with the most bookings
function findMaxArea(areas) {
  let maxArea = "";
  let maxBookings = 0;
  for (const area in areas) {
    if (areas[area] > maxBookings) {
      maxArea = area;
      maxBookings = areas[area];
    }
  }
  return { maxArea, maxBookings };
}

// Main function to determine if the tour should be recommended
async function willRecommend(userData, tourData) {
  try {
    const tourCountry = tourData.country;
    const userBookings = userData.bookedTours;

    const tours = await fetchUserBookedTours(userBookings);

    const areas = createAreasMap(tours);
    const { maxArea } = findMaxArea(areas);

    if (tourCountry === maxArea) {
      return true;
    }

    return false;
  } catch (error) {
    console.error("Error getting location:", error);
  }
}

module.exports = {
  willRecommend,
};
