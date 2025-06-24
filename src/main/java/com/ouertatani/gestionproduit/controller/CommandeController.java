package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.Commande;
import com.ouertatani.gestionproduit.service.CommandeService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/commande")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CommandeController {

    private final CommandeService service;

    @PostMapping("/acheter")
    public ResponseEntity<Commande> acheter(@RequestBody AchatRequest request) {
        Commande commande = service.ajouterProduitAuPanier(
                request.getClientId(),
                request.getProduitId(),
                request.getQuantite()
        );
        return ResponseEntity.ok(commande);
    }

    @GetMapping("/panier/{clientId}")
    public ResponseEntity<Commande> getPanier(@PathVariable Long clientId) {
        return ResponseEntity.ok(service.getPanierClient(clientId));
    }

    @PostMapping("/confirmer")
    public ResponseEntity<Commande> confirmer(@RequestBody ConfirmationRequest request) {
        return ResponseEntity.ok(service.confirmerCommande(
                request.getCommandeId(),
                request.getAdresseLivraison()
        ));
    }

    @Data
    public static class AchatRequest {
        private Long clientId;
        private Long produitId;
        private int quantite;
    }

    @Data
    public static class ConfirmationRequest {
        private Long commandeId;
        private String adresseLivraison;
    }
}
