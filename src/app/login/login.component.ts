import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ApiService } from '../services/api.service'; // Corrigé depuis '../core/services/auth.service'
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    TranslateModule,
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css'],
})
export class LoginComponent {
  loginForm: FormGroup;
  errorMessage: string | null = null;
  isLoading = false;

  constructor(private fb: FormBuilder, private apiService: ApiService, private router: Router) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
    });
  }

  onSubmit() {
    if (this.loginForm.valid) {
      this.isLoading = true;
      this.errorMessage = null;
      const { email, password } = this.loginForm.value;
      this.apiService.login(email, password).subscribe({
        next: (response) => {
          const token = response.token;
          if (token) {
            localStorage.setItem('jwt_token', token);
            this.apiService.getCurrentUser().subscribe({
              next: (user) => {
                if (user.id !== undefined && user.id !== null) {
                  localStorage.setItem('client_id', user.id.toString());
                }
                if (user.typeUtilisateur === 'ADMIN') {
                  this.errorMessage = 'Les administrateurs ne sont pas autorisés à se connecter ici.';
                  this.apiService.logout();
                } else if (user.typeUtilisateur === 'CLIENT' || user.typeUtilisateur === 'FOURNISSEUR') {
                  this.router.navigate(['/dashboard']);
                } else {
                  this.errorMessage = 'Type d\'utilisateur inconnu';
                }
                this.isLoading = false;
              },
              error: (err) => {
                this.errorMessage = 'Erreur lors de la récupération de l\'utilisateur';
                this.isLoading = false;
              },
            });
          } else {
            this.errorMessage = 'Token non reçu';
            this.isLoading = false;
          }
        },
        error: (err) => {
          this.errorMessage = err.status === 401 ? 'Email ou mot de passe incorrect' : 'Erreur de connexion au serveur';
          this.isLoading = false;
        },
      });
    }
  }
}