import { Component, OnInit, ViewEncapsulation, inject } from '@angular/core';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RouterLink } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { ApiService } from '../services/api.service';
import { Utilisateur } from '../models/utilisateur.model';

@Component({
  selector: 'app-user-panel',
  template: `
    <div class="matero-user-panel" routerLink="/profile/overview" matTooltip="View Profile" matTooltipPosition="right">
      <img class="matero-user-panel-avatar" src='../../assets/images/default-avatar.png' alt="avatar" width="48" />
      <div class="matero-user-panel-info">
        <h4 class="matero-user-panel-name">{{ user?.nom || 'User' }} {{ user?.prenom || '' }}</h4>
        <h5 class="matero-user-panel-email">{{ user?.email || 'N/A' }}</h5>
      </div>
    </div>
  `,
  styleUrl: './user-panel.scss',
  encapsulation: ViewEncapsulation.None,
  standalone: true,
  imports: [RouterLink, MatTooltipModule, TranslateModule],
})
export class UserPanel implements OnInit {
  private readonly apiService = inject(ApiService);
  user: Utilisateur | null = null;

  ngOnInit(): void {
    const token = localStorage.getItem('jwt_token');
    if (token) {
      this.apiService.getCurrentUser().subscribe({
        next: (user) => {
          this.user = user;
        },
        error: (err) => {
          console.error('Error fetching user:', err);
        },
      });
    }
  }
}