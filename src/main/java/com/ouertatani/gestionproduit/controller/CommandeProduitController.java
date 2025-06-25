package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.CommandeProduit;
import com.ouertatani.gestionproduit.service.CommandeProduitService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/commande-produits")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CommandeProduitController {

    private final CommandeProduitService service;

    @GetMapping
    public ResponseEntity<List<CommandeProduit>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/commande/{commandeId}")
    public ResponseEntity<List<CommandeProduit>> getByCommandeId(@PathVariable Long commandeId) {
        return ResponseEntity.ok(service.getByCommandeId(commandeId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CommandeProduit> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    public ResponseEntity<CommandeProduit> create(@RequestBody CommandeProduit cp) {
        return ResponseEntity.ok(service.save(cp));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/commande-produits/{id}/augmenter")
    public ResponseEntity<?> augmenterQuantite(@PathVariable Long id) {
        return ResponseEntity.ok(service.augmenterQuantite(id));
    }

    @PutMapping("/commande-produits/{id}/diminuer")
    public ResponseEntity<?> diminuerQuantite(@PathVariable Long id) {
        return ResponseEntity.ok(service.diminuerQuantite(id));
    }

    @DeleteMapping("/commande-produits/{id}")
    public ResponseEntity<?> supprimer(@PathVariable Long id) {
        service.supprimer(id);
        return ResponseEntity.ok().build();
    }

}
