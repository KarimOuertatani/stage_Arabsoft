package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.Livraison;
import com.ouertatani.gestionproduit.service.LivraisonService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/livraisons")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LivraisonController {

    private final LivraisonService service;

    @GetMapping
    public ResponseEntity<List<Livraison>> getAll() {
        return ResponseEntity.ok(service.getAll());
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

    @Data
    public static class StatutRequest {
        private Livraison.StatutLivraison statut;
    }
}
