# Maintainer: William Varmus <0@willvar.tw>

_extname=jsonpath
pkgname=php-$_extname
pkgdesc='Extract data using JSONPath notation for PHP'
pkgver=3.0.0
pkgrel=1
arch=('x86_64')
url='https://github.com/supermetrics-public/pecl-jsonpath'
license=('PHP License')
depends=('php>=8.0')
source=("http://pecl.php.net/get/$_extname-$pkgver.tgz")
sha256sums=('198ae484102b4404d94e2ad0b38d1dbf78ec55067f0b92f0dfaa2afcad906268')

build() {
  cd $srcdir/$_extname-$pkgver
  echo "extension=$_extname" > $_extname.ini
  phpize
  patch -p0 < ../../test-failure.diff
  ./configure --prefix=/usr --enable-jsonpath
  make
}

check() {
  cd $srcdir/$_extname-$pkgver
  NO_INTERACTION=true make test
}

package() {
  cd $srcdir/$_extname-$pkgver
  make INSTALL_ROOT=$pkgdir install
  install -Dm644 $_extname.ini $pkgdir/etc/php/conf.d/$_extname.ini \
  && install -vDm 644 LICENSE -t $pkgdir/usr/share/licenses/$pkgname
}