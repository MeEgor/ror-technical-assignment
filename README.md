# Test assessment completed

Api available at http://localhost:3000/api/cars


# Introduction

We want to build a car market platform and provide a personalized selection of cars to our users. There are few main models:

* `Brand(name)` - car brands like Mercedes-Benz, Toyota, Volkswagen, BMW.
* `Car(model_name, brand_id, price)` -  cars for sale.
* `User(email, preferred_price_range)` - our users who want to buy a car.
* `UserPreferredBrand(user_id, brand_id)` - relationship to connect the user and his preferred car brands.

We already prepared rails models and seeds data that you can use but feel free to make any changes here (including model relations, validations, database changes etc).

We also have an external recommendation service with modern AI algorithms. The service provides recommended cars for the user. There is the API endpoint `https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id=<USER_ID>` with the following response schema:

```
[
  {
    car_id: <car id>, # car id from seeds data
    rank_score: <number between 0..1> # the higher, then the car the more relevant to the user
  },
  ...
]
```

The response will contain only the top 10 recommended cars for the user. Like many modern AI algorithms, our service not always work well and sometimes can be unavailable or respond with errors. Also, it's not a real-time solution and has updated data only one time every day.

# Assignment


You need to build API endpoint that will accept the following parameters:

```
{
  "user_id": <user id (required)>
  "query": <car brand name or part of car brand name to filter by (optional)>
  "price_min": <minimum price (optional)>
  "price_max": <maximum price (optional)>
  "page": <page number for pagination (optional, default 1, default page size is 20)>
}
```

The API endpoint should return paginated cars list filtered by params passed with the following rules:

1. On top it should be cars with `perfect_match` label. This cars have match with user preferred car brands ( `user.preferred_brands.include?(car.brand) == true`) and with preferred price (`user.preferred_price_range.include?(car.price) == true`).
2. Then we should have `good_match` offers. These offers have the only user preferred car brands (`user.preferred_brands.include?(car.brand) == true`).
3. Then goes top 5 cars suggested by external recommendation service API (they can also be matched as perfect and good matches).
4. Then goes all other cars sorted by price (ASC).

Schema of response:
```
[
  {
    "id": <car id>
    "brand": {
      id: <car brand id>,
      name: <car brand name>
    },
    "price": <car price>,
    "rank_score": <rank score>,
    "model": <car model>,
    "label": <perfect_match|good_match|nil>
  },
  ...
]
```

# Example of response

Suppose that the user has preferred brands as `Alfa Romeo` and `Volkswagen` and preferred price `35_000...40_000`. The external recommendation service return for this user following data:
```
[
  { "car_id": 179, "rank_score": 0.945 },
  { "car_id": 5, "rank_score": 0.4552 },
  { "car_id": 180, "rank_score": 0.567 },
  { "car_id": 97, "rank_score": 0.9489 },
  { "car_id": 86, "rank_score": 0.2183 },
  { "car_id": 32, "rank_score": 0.0967 },
  { "car_id": 176, "rank_score": 0.0353 },
  { "car_id": 177, "rank_score": 0.1657 },
  { "car_id": 186, "rank_score": 0.7068 },
  { "car_id": 103, "rank_score": 0.4729 }
]
```
Then based on seeds data if you request the API with the following params:
```
{
  "user_id": 1,
  "page": 1
}
```
the response from API should be:
```
[
  {
    "id": 179,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "Derby",
    "price": 37230,
    "rank_score": 0.945,
    "label": "perfect_match"
  },
  {
    "id": 180,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "e-Golf",
    "price": 35131,
    "rank_score": 0.567,
    "label": "perfect_match"
  },
  {
    "id": 5,
    "brand": {
      "id": 2,
      "name": "Alfa Romeo"
    },
    "model": "Arna",
    "price": 39938,
    "rank_score": 0.4552,
    "label": "perfect_match"
  },
  {
    "id": 186,
    "brand": {
      "id": 2,
      "name": "Alfa Romeo"
    },
    "model": "Brera",
    "price": 40938,
    "rank_score": 0.7068,
    "label": "good_match"
  },
  {
    "id": 181,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "Amarok",
    "price": 31743,
    "rank_score": null,
    "label": "good_match"
  },
  {
    "id": 97,
    "brand": {
      "id": 20,
      "name": "Lexus"
    },
    "model": "IS 220",
    "price": 39858,
    "rank_score": 0.9489,
    "label": null
  },
  {
    "id": 103,
    "brand": {
      "id": 22,
      "name": "Lotus"
    },
    "model": "Eclat",
    "price": 48953,
    "rank_score": 0.4729,
    "label": null
  },
  {
    "id": 113,
    "brand": {
      "id": 24,
      "name": "Mazda"
    },
    "model": "3",
    "price": 1542,
    "rank_score": null,
    "label": null
  },
  {
    "id": 100,
    "brand": {
      "id": 20,
      "name": "Lexus"
    },
    "model": "RX 300",
    "price": 1972,
    "rank_score": null,
    "label": null
  },
  {
    "id": 184,
    "brand": {
      "id": 40,
      "name": "Volvo"
    },
    "model": "610",
    "price": 3560,
    "rank_score": null,
    "label": null
  },
  {
    "id": 142,
    "brand": {
      "id": 31,
      "name": "Ram"
    },
    "model": "Promaster City",
    "price": 3687,
    "rank_score": null,
    "label": null
  },
  {
    "id": 120,
    "brand": {
      "id": 26,
      "name": "Mercury"
    },
    "model": "Marauder",
    "price": 3990,
    "rank_score": null,
    "label": null
  },
  {
    "id": 109,
    "brand": {
      "id": 23,
      "name": "Maserati"
    },
    "model": "Levante",
    "price": 4243,
    "rank_score": null,
    "label": null
  },
  {
    "id": 89,
    "brand": {
      "id": 16,
      "name": "Infiniti"
    },
    "model": "M25",
    "price": 4372,
    "rank_score": null,
    "label": null
  },
  {
    "id": 164,
    "brand": {
      "id": 35,
      "name": "Smart"
    },
    "model": "Forfour",
    "price": 4391,
    "rank_score": null,
    "label": null
  },
  {
    "id": 81,
    "brand": {
      "id": 14,
      "name": "Honda"
    },
    "model": "Pilot",
    "price": 4473,
    "rank_score": null,
    "label": null
  },
  {
    "id": 182,
    "brand": {
      "id": 40,
      "name": "Volvo"
    },
    "model": "265",
    "price": 5208,
    "rank_score": null,
    "label": null
  },
  {
    "id": 54,
    "brand": {
      "id": 10,
      "name": "Dodge"
    },
    "model": "Ramcharger",
    "price": 5425,
    "rank_score": null,
    "label": null
  },
  {
    "id": 108,
    "brand": {
      "id": 23,
      "name": "Maserati"
    },
    "model": "Coupe",
    "price": 5508,
    "rank_score": null,
    "label": null
  },
  {
    "id": 86,
    "brand": {
      "id": 16,
      "name": "Infiniti"
    },
    "model": "M37",
    "price": 5698,
    "rank_score": 0.2183,
    "label": null
  }
]
```

If you add `"query": "Volks"` parameter to the request then only cars with a brand name that includes `Volks` should be in the response. The same logic for `price_min` and `price_max`.

# Criteria for evaluation

* API endpoint should work fast with growing data in DB
* The code should be decomposed to make changes easily
* Test coverage to be sure that everything works well

# Notes

You can use any gems and make any changes in the repo.
