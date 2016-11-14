#include "srlua.c"

#include <fcntl.h>
#include <io.h>
#include <process.h>

#include "resource.h"

static int thRet;
static void thMain( void *vp) {

	thRet = main( __argc, __argv);

	fclose( stdout);
	fclose( stderr);
}

INT_PTR CALLBACK txtDP( HWND hwndDlg, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	
	switch( uMsg) {
	case WM_COMMAND:
		switch( LOWORD( wParam)) {
		case IDOK:
			PostQuitMessage( 0);
			break;
		}
		break;
	}

	return 0;
}


int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
				   LPSTR lpCmdLine, int nCmdShow) {

	char buf[1024];
	char *p;
	int i, off;
	int pips[3];
	HWND hDlg, hTxt;

	hDlg = CreateDialog( hInstance, MAKEINTRESOURCE( IDD_DIALOG1), GetDesktopWindow(), txtDP);
	GetModuleFileName( NULL, buf, sizeof( buf));
	p = strrchr( buf, '.');
	if( p != NULL)
		*p = 0;
	p = strrchr( buf, '\\');
	if( p == NULL)
		p = buf;
	else
		p++;
	SendMessage( hDlg, WM_SETTEXT, 0, ( LPARAM) p);
	hTxt = GetDlgItem( hDlg, IDC_EDIT1);

	_pipe( pips, 512, _O_TEXT);
	pips[2] = _dup( pips[1]);

	stdout->_file = pips[1];
	stderr->_file = pips[2];

	_beginthread( thMain, 0, NULL);

	for( off = 0; off < 65536L - 1024L;) {
		for( i = 0; i < ( sizeof( buf) - 2); i++) {
			if( _read( pips[0], buf + i, 1) < 1)
				break;
			if( buf[i] == '\n') {
				buf[i++] = '\r';
				buf[i] = '\n';
			}
		}
		if( i) {
			buf[i] = 0;
			SendMessage( hTxt, EM_SETSEL, off, off);
			SendMessage( hTxt, EM_REPLACESEL, FALSE, ( LPARAM) buf);
			off += i;
		}
		if( i < ( sizeof( buf) - 1))
			break;
	}
	if( off) {
		MSG msg;
		ShowWindow( hDlg, SW_SHOW);
		while( GetMessage( &msg, NULL, 0, 0))
			DispatchMessage( &msg);
		ShowWindow( hDlg, SW_HIDE);
	}
	DestroyWindow( hDlg);

	return thRet;
}

