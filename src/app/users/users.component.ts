import { Component, OnInit, ViewChild, HostListener } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Utilisateur } from '../models/utilisateur.model';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { Inject } from '@angular/core';

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    MatSelectModule,
    MatFormFieldModule,
    MatDialogModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
  ]
})
export class UsersComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  utilisateurs: Utilisateur[] = [];
  filteredUtilisateurs: Utilisateur[] = [];
  userColumns = ['id', 'nom', 'email', 'numeroTelephone', 'dateNaissance', 'type', 'actions'];
  selectedRole: string = '';
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  userChartData: ChartData<'pie'> = {
    labels: ['Admin', 'Client', 'Fournisseur'],
    datasets: [
      {
        data: [0, 0, 0],
        backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'right',
        labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } }
      },
      tooltip: {
        enabled: true,
        backgroundColor: '#1f2a44',
        titleFont: { family: 'Inter, Roboto, sans-serif' },
        bodyFont: { family: 'Inter, Roboto, sans-serif' }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router, private dialog: MatDialog) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit() {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadUsers();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  private loadUsers() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getUtilisateurs().subscribe({
      next: (utilisateurs) => {
        this.utilisateurs = utilisateurs;
        this.filteredUtilisateurs = utilisateurs;
        this.updateChartData();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des utilisateurs:', err);
        this.errorMessage = 'Failed to load users. Please try again.';
        this.isLoading = false;
      }
    });
  }

  private updateChartData() {
    const counts = {
      ADMIN: 0,
      CLIENT: 0,
      FOURNISSEUR: 0
    };
    this.filteredUtilisateurs.forEach(user => counts[user.typeUtilisateur]++);
    this.userChartData.datasets[0].data = [counts.ADMIN, counts.CLIENT, counts.FOURNISSEUR];
  }

  filterUsers() {
    if (this.selectedRole) {
      this.filteredUtilisateurs = this.utilisateurs.filter(user => user.typeUtilisateur === this.selectedRole);
    } else {
      this.filteredUtilisateurs = this.utilisateurs;
    }
    this.updateChartData();
  }

  updateUser(id: number) {
    console.log(`Update user with ID: ${id}`);
    // Implémenter la logique de mise à jour (ex. : naviguer vers un formulaire)
  }

  openDeleteDialog(id: number, userName: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '350px',
      data: { message: `Are you sure you want to delete user ${userName}?` }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.deleteUser(id);
      }
    });
  }

  deleteUser(id: number) {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.deleteUtilisateur(id).subscribe({
      next: () => {
        this.utilisateurs = this.utilisateurs.filter(user => user.id !== id);
        this.filterUsers();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la suppression de l\'utilisateur:', err);
        this.errorMessage = 'Failed to delete user. Please try again.';
        this.isLoading = false;
      }
    });
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadUsers();
  }
}

@Component({
  selector: 'app-confirm-dialog',
  template: `
    <h2 mat-dialog-title>Confirm Deletion</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancel</button>
      <button mat-button color="warn" (click)="dialogRef.close(true)">Delete</button>
    </mat-dialog-actions>
  `,
  standalone: true,
  imports: [MatDialogModule, MatButtonModule]
})
export class ConfirmDialogComponent {
  constructor(public dialogRef: MatDialogRef<ConfirmDialogComponent>, @Inject(MAT_DIALOG_DATA) public data: { message: string }) {}
}