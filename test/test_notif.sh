curl -X POST \
  --header "Authorization: key=AAAApvVlKa0:APA91bG92T1ovN38wATkOkqcIzjA7hzwFdLEkROqRQGEgpFUhC0QKhEhww7Ma8cC3h_8zzxB5bTtWDC6tdbfhcDi08jQl6-r0-ugPA1rJ7iiCOHQ0G3hjrfZlB9oPvEcdolDM8FlEEy2" \
  --header "Content-Type: application/json" \
  --data '{
    "to": "chz67PMtqkkitzEhhz6COZ:APA91bF0nT2CvzwKEqjvKzY2zAtep3Qc00wHDwYF_T3_TIYKpoBSdh4PkvLjpOeKnKRkk4Faimj1NO4gu-dK_5kQSQmn-gGbA5HlSnQjlTLJUaUwgr7guwfMbbzp--JtxL-SzVXLMpau",
    "content_available": true,
    "priority": "high",
    "data": {
      "custom_key": "custom_value"
    }
  }' \
  https://fcm.googleapis.com/fcm/send
