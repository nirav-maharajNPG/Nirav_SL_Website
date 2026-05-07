# Deployment Guide: www.storagelocker.co.za

I have prepared your project for deployment and initiated the initial file transfer. Follow these steps to complete the setup and make the site live on your domain.

## 1. Initial Deployment (In Progress)
I have already started an initial `scp` transfer of your files to the server (`18.130.137.24`) at `/var/www/storagelocker`. 
> [!NOTE]
> Since the assets folder is ~95MB, this may take a few more minutes to complete in the background.

## 2. Nginx Configuration (Applied)
I have already uploaded and enabled the Nginx configuration on your server.
- **Config Path**: `/etc/nginx/sites-available/storagelocker`
- **Domain**: `storagelocker.co.za` and `www.storagelocker.co.za`
- **Root**: `/var/www/storagelocker`

## 3. GitHub Actions Setup
To enable automatic deployments whenever you push to the `master` branch, you need to add three secrets to your GitHub repository:
1. Go to your repository on GitHub.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret** and add the following:

| Secret Name | Value |
| :--- | :--- |
| `SERVER_HOST` | `18.130.137.24` |
| `SERVER_USER` | `ubuntu` |
| `SERVER_KEY` | *(Copy the contents of `~/.ssh/lightsail_new_key`)* |

> [!TIP]
> You can get the key content by running: `cat ~/.ssh/lightsail_new_key` in your terminal.

## 4. DNS Configuration
Point your domain to the server by updating your DNS records at your domain registrar (e.g., GoDaddy, Namecheap):

| Type | Host | Value |
| :--- | :--- | :--- |
| **A** | `@` | `18.130.137.24` |
| **A** | `www` | `18.130.137.24` |

## 5. SSL (HTTPS) Setup
Once your DNS has propagated (usually 1-24 hours), run the following command on your server to enable HTTPS:
```bash
sudo certbot --nginx -d storagelocker.co.za -d www.storagelocker.co.za
```

## Summary of Files Created
- `.github/workflows/deploy.yml`: Automates deployment on git push.
- `nginx.conf`: Server configuration (already applied to the server).
