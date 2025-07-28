package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.CodeSecretClient;
import com.ouertatani.gestionproduit.model.Utilisateur;
import com.ouertatani.gestionproduit.service.CodeSecretClientService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.SecureRandom;
import java.util.Optional;

@RestController
@RequestMapping("/api/code-secret")
public class CodeSecretClientController {
    private static final Logger logger = LoggerFactory.getLogger(CodeSecretClientController.class);
    private static final String CODE_CHARS = "0123456789";
    private static final int CODE_LENGTH = 6;

    @Autowired
    private CodeSecretClientService service;

    @PostMapping("/create")
    public ResponseEntity<CodeSecretClient> createCodeSecret(@RequestBody Integer utilisateurId) {
        if (utilisateurId == null || utilisateurId <= 0) {
            logger.warn("Invalid utilisateurId: {}", utilisateurId);
            return ResponseEntity.badRequest().body(null);
        }

        // Generate random 6-digit code
        String codeSecret = generateRandomCode();

        // Create CodeSecretClient with utilisateur
        CodeSecretClient code = new CodeSecretClient();
        Utilisateur utilisateur = new Utilisateur();
        utilisateur.setId(utilisateurId);
        code.setUtilisateur(utilisateur);
        code.setCodeSecret(codeSecret);

        logger.info("Creating code for utilisateurId: {}", utilisateurId);
        CodeSecretClient saved = service.save(code);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{utilisateurId}")
    public ResponseEntity<CodeSecretClient> getCodeSecret(@PathVariable Integer utilisateurId) {
        if (utilisateurId == null || utilisateurId <= 0) {
            logger.warn("Invalid utilisateurId: {}", utilisateurId);
            return ResponseEntity.badRequest().body(null);
        }

        logger.info("Fetching code for utilisateurId: {}", utilisateurId);
        Optional<CodeSecretClient> optional = service.findByUtilisateurId(utilisateurId);
        if (optional.isPresent()) {
            return ResponseEntity.ok(optional.get());
        } else {
            logger.warn("No code found for utilisateurId: {}", utilisateurId);
            return ResponseEntity.notFound().build();
        }
    }

    private String generateRandomCode() {
        SecureRandom random = new SecureRandom();
        StringBuilder code = new StringBuilder(CODE_LENGTH);
        for (int i = 0; i < CODE_LENGTH; i++) {
            int index = random.nextInt(CODE_CHARS.length());
            code.append(CODE_CHARS.charAt(index));
        }
        return code.toString();
    }

    @PostMapping("/verify")
    public ResponseEntity<String> verifyCodeSecret(@RequestBody VerifyCodeRequest request) {
        if (request.getUtilisateurId() == null || request.getUtilisateurId() <= 0) {
            logger.warn("Invalid utilisateurId: {}", request.getUtilisateurId());
            return ResponseEntity.badRequest().body("Invalid utilisateurId");
        }
        if (request.getCodeSecret() == null || request.getCodeSecret().isEmpty() || request.getCodeSecret().length() > 10) {
            logger.warn("Invalid codeSecret for utilisateurId: {}", request.getUtilisateurId());
            return ResponseEntity.badRequest().body("Invalid codeSecret");
        }
        logger.info("Verifying code for utilisateurId: {}", request.getUtilisateurId());
        Optional<CodeSecretClient> optional = service.findByUtilisateurIdAndCodeSecret(
                request.getUtilisateurId(), request.getCodeSecret());
        if (optional.isPresent()) {
            logger.info("Valid code for utilisateurId: {}", request.getUtilisateurId());
            return ResponseEntity.ok("Code secret valide");
        } else {
            logger.warn("Invalid code for utilisateurId: {}", request.getUtilisateurId());
            return ResponseEntity.status(401).body("Code secret invalide");
        }
    }

    public static class VerifyCodeRequest {
        private Integer utilisateurId;
        private String codeSecret;

        public Integer getUtilisateurId() { return utilisateurId; }
        public void setUtilisateurId(Integer utilisateurId) { this.utilisateurId = utilisateurId; }
        public String getCodeSecret() { return codeSecret; }
        public void setCodeSecret(String codeSecret) { this.codeSecret = codeSecret; }
    }
}