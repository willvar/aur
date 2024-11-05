# Maintainer: Leo <i@setuid0.dev>
# Maintainer: William Varmus

_extname=uuid
pkgname=php-$_extname
pkgver=1.2.1
pkgrel=1
pkgdesc='PHP PECL UUID extension'
arch=('x86_64')
url="https://pecl.php.net/package/$_extname"
license=('LGPL')
depends=('php>=7.0')
source=("http://pecl.php.net/get/$_extname-$pkgver.tgz")
sha256sums=('2235c8584ca8911ce5512ebf791e5bb1d849c323640ad3e0be507b00156481c7')

build() {
    cd $srcdir/$_extname-$pkgver
	echo "extension=$_extname" > $_extname.ini
    phpize
    ./configure \
    --prefix=/usr \
    --with-uuid
    make
}

check() {
	cd $srcdir/$_extname-$pkgver
	NO_INTERACTION=1 make test
}

package() {
    cd $srcdir/$_extname-$pkgver
    make INSTALL_ROOT=$pkgdir install
    install -Dm644 $_extname.ini $pkgdir/etc/php/conf.d/$_extname.ini
}
