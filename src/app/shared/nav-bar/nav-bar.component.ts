import { Component } from '@angular/core';
import { AuthService } from '../../core/authentication/auth.service';
import { Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { RouterLink, RouterLinkActive } from '@angular/router';

@Component({
  selector: 'app-nav-bar',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.scss'],
  imports: [MatButtonModule, RouterLink, RouterLinkActive],
  standalone: false
})
export class NavBarComponent {
  constructor(public authService: AuthService, private router: Router) {}

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}