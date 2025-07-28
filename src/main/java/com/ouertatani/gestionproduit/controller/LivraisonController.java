package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.Livraison;
import com.ouertatani.gestionproduit.model.LivraisonDTO;
import com.ouertatani.gestionproduit.service.LivraisonService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/livraisons")
@RequiredArgsConstructor
//@CrossOrigin(origins = "*")
public class LivraisonController {

    private final LivraisonService service;
    private final JavaMailSenderImpl mailSender;

    @GetMapping
    public ResponseEntity<List<LivraisonDTO>> getAll() {
        return ResponseEntity.ok(service.getAll_DTO());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Livraison> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}/statut")
    public ResponseEntity<Livraison> updateStatut(@PathVariable Long id, @RequestBody StatutRequest request) {
        Livraison updated = service.updateStatut(id, request.getStatut());
        return ResponseEntity.ok(updated);
    }
    @PostMapping("/{id}/notify")
    public ResponseEntity<Void> sendNotification(@PathVariable Long id, @RequestBody NotificationRequest request) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getEmail());
        message.setSubject("Mise à jour de votre livraison");
        message.setText("Bonjour " + request.getClientName() + ",\n\nVotre livraison (ID: " + id + ") est maintenant EN COURS.\n\nCordialement,\nL'équipe Smart Inventory");
        mailSender.send(message);
        return ResponseEntity.ok().build();
    }
    @Data
    public static class StatutRequest {
        private Livraison.StatutLivraison statut;
    }
    @Data
    public static class NotificationRequest {
        private String email;
        private String clientName;
    }
}
