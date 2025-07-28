package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.Utilisateur;
import com.ouertatani.gestionproduit.service.UtilisateurService;
import com.ouertatani.gestionproduit.service.CodeSecretClientService;
import com.ouertatani.gestionproduit.model.CodeSecretClient;
import com.ouertatani.gestionproduit.util.JwtUtil;
import javax.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.persistence.EntityNotFoundException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/utilisateurs")
public class UtilisateurController {

    private final UtilisateurService utilisateurService;
    private final JwtUtil jwtUtil;
    private final CodeSecretClientService codeSecretClientService;

    public UtilisateurController(UtilisateurService utilisateurService, JwtUtil jwtUtil, CodeSecretClientService codeSecretClientService) {
        this.utilisateurService = utilisateurService;
        this.jwtUtil = jwtUtil;
        this.codeSecretClientService = codeSecretClientService;
    }

    @GetMapping
    public List<Utilisateur> getAllUtilisateurs() {
        return utilisateurService.getAllUtilisateurs();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Utilisateur> getUtilisateurById(@PathVariable Integer id) {
        Optional<Utilisateur> utilisateur = utilisateurService.getUtilisateurById(id);
        return utilisateur.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/current")
    public ResponseEntity<?> getCurrentUtilisateur(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            String token = authorizationHeader.replace("Bearer ", "");
            String email = jwtUtil.extractEmail(token);
            Optional<Utilisateur> utilisateur = utilisateurService.getUtilisateurByEmail(email);
            if (utilisateur.isPresent()) {
                return ResponseEntity.ok(utilisateur.get());
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Utilisateur non trouvé");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Token invalide ou expiré");
        }
    }

    @PostMapping
    public ResponseEntity<Utilisateur> createUtilisateur(@Valid @RequestBody Utilisateur utilisateur) {
        try {
            Utilisateur savedUtilisateur = utilisateurService.saveUtilisateur(utilisateur);
            return new ResponseEntity<>(savedUtilisateur, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Optional<Utilisateur> utilisateur = utilisateurService.authenticate(loginRequest.getEmail(), loginRequest.getMotDePasse());
        if (utilisateur.isPresent()) {
            String token = jwtUtil.generateToken(utilisateur.get().getEmail(), utilisateur.get().getTypeUtilisateur().toString());
            return ResponseEntity.ok(new LoginResponse(token));
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Email ou mot de passe incorrect");
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        try {
            // Vérifier si l'utilisateur existe par email
            Optional<Utilisateur> utilisateurOpt = utilisateurService.getUtilisateurByEmail(request.getEmail());
            if (!utilisateurOpt.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Utilisateur non trouvé");
            }

            Utilisateur utilisateur = utilisateurOpt.get();

            // Vérifier la date de naissance
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate providedDate = LocalDate.parse(request.getDateNaissance(), formatter);
            LocalDate userDate = utilisateur.getDateNaissance();
            if (userDate == null || !userDate.equals(providedDate)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Date de naissance incorrecte");
            }

            // Vérifier le code secret
            Optional<CodeSecretClient> codeOpt = codeSecretClientService.findByUtilisateurIdAndCodeSecret(
                    utilisateur.getId(), request.getCodeSecret());
            if (!codeOpt.isPresent()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Code secret incorrect");
            }

            // Mettre à jour le mot de passe
            utilisateurService.updatePassword(utilisateur.getId(), request.getNewPassword());
            return ResponseEntity.ok("Mot de passe réinitialisé avec succès");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Erreur : " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Utilisateur> updateUtilisateur(@PathVariable Integer id, @Valid @RequestBody Utilisateur utilisateurDetails) {
        try {
            Utilisateur updatedUtilisateur = utilisateurService.updateUtilisateur(id, utilisateurDetails);
            return ResponseEntity.ok(updatedUtilisateur);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUtilisateur(@PathVariable Integer id) {
        try {
            utilisateurService.deleteUtilisateur(id);
            return ResponseEntity.noContent().build();
        } catch (EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    public static class LoginRequest {
        private String email;
        private String motDePasse;

        public LoginRequest() {}

        public LoginRequest(String email, String motDePasse) {
            this.email = email;
            this.motDePasse = motDePasse;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getMotDePasse() {
            return motDePasse;
        }

        public void setMotDePasse(String motDePasse) {
            this.motDePasse = motDePasse;
        }
    }

    public static class LoginResponse {
        private String token;

        public LoginResponse(String token) {
            this.token = token;
        }

        public String getToken() {
            return token;
        }

        public void setToken(String token) {
            this.token = token;
        }
    }

    public static class ResetPasswordRequest {
        private String email;
        private String dateNaissance;
        private String codeSecret;
        private String newPassword;

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getDateNaissance() {
            return dateNaissance;
        }

        public void setDateNaissance(String dateNaissance) {
            this.dateNaissance = dateNaissance;
        }

        public String getCodeSecret() {
            return codeSecret;
        }

        public void setCodeSecret(String codeSecret) {
            this.codeSecret = codeSecret;
        }

        public String getNewPassword() {
            return newPassword;
        }

        public void setNewPassword(String newPassword) {
            this.newPassword = newPassword;
        }
    }
}