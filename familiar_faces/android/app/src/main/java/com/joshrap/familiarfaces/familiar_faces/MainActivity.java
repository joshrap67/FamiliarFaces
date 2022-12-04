package com.joshrap.familiarfaces.familiar_faces;

import android.os.Build;
import android.os.Bundle;
import android.window.SplashScreenView;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			// Disable the Android splash screen fade out animation to avoid
			// a flicker before the similar frame is drawn in Flutter.
			getSplashScreen().setOnExitAnimationListener(SplashScreenView::remove);
		}

		super.onCreate(savedInstanceState);
	}
}
