package com.ouertatani.gestionproduit.service;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class StripeService {

    private static final String STRIPE_SECRET_KEY = "sk_test_51OHotbIUNFbNVA8jKmPysVIRp7D8UsENtR2DrUiwRZlKwmcBBilKGG4UXNBxjXnk6LcTukxPndb3SoxoCA6PFg5b00QeQtkZ08"; // Remplace par ta clé secrète Stripe

    public StripeService() {
        Stripe.apiKey = STRIPE_SECRET_KEY;
    }

    public Map<String, String> createPaymentIntent(Long amount, String currency) throws StripeException {
        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(amount)
                .setCurrency(currency)
                .build();

        PaymentIntent intent = PaymentIntent.create(params);

        Map<String, String> response = new HashMap<>();
        response.put("clientSecret", intent.getClientSecret());
        return response;
    }
}
