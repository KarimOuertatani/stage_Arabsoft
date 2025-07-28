package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.service.StripeService;
import com.stripe.exception.StripeException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/stripe")
@RequiredArgsConstructor
//@CrossOrigin(origins = "*")
public class StripeController {

    private final StripeService stripeService;

    @PostMapping("/create-payment-intent")
    public ResponseEntity<Map<String, String>> createPaymentIntent(@RequestParam Long amount) {
        Map<String, String> response = new HashMap<>();

        // Validation du montant
        if (amount == null || amount <= 0) {
            response.put("error", "Montant invalide: doit être supérieur à 0");
            return ResponseEntity.badRequest().body(response);
        }

        try {
            // Appel au service Stripe
            Map<String, String> paymentIntent = stripeService.createPaymentIntent(amount, "eur");
            return ResponseEntity.ok(paymentIntent);
        } catch (StripeException e) {
            response.put("error", "Erreur Stripe: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("error", "Erreur interne: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
}