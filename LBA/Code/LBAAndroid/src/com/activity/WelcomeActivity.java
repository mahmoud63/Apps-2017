package com.activity;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.location.Location;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.Window;

import com.constant.AndroidConstants;
import com.helper.ReverseGeocoder;
import com.helper.StringHelper;

public class WelcomeActivity extends CommonActivity {

	@SuppressLint("NewApi")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		android.os.StrictMode.ThreadPolicy tp = android.os.StrictMode.ThreadPolicy.LAX;
		android.os.StrictMode.setThreadPolicy(tp);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.welcome);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		checkConnectivity();
	}

	protected int _splashTime = 2000;

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.welcome, menu);
		return true;
	}

	public void checkConnectivity() {
		runOnUiThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				SharedPreferences s = PreferenceManager
						.getDefaultSharedPreferences(WelcomeActivity.this);

				boolean success = checkConnectivityServer();
				if (success) {
					SharedPreferences.Editor editor = s.edit();
					editor.putString("MAIN_SERVER_IP",
							AndroidConstants.MAIN_SERVER_IP + "");
					editor.putString("MAIN_SERVER_PORT",
							AndroidConstants.MAIN_SERVER_PORT + "");
					editor.commit();
					checkUserDetails();

				} else {

					String MAIN_SERVER_IP = s.getString("MAIN_SERVER_IP",
							AndroidConstants.MAIN_SERVER_IP);
					String MAIN_SERVER_PORT = s.getString("MAIN_SERVER_PORT",
							AndroidConstants.MAIN_SERVER_PORT);
					if (!MAIN_SERVER_IP
							.equalsIgnoreCase(AndroidConstants.MAIN_SERVER_IP)
							|| !MAIN_SERVER_PORT
									.equalsIgnoreCase(AndroidConstants.MAIN_SERVER_PORT)) {
						success = checkConnectivityServer(MAIN_SERVER_IP,
								StringHelper.n2i(MAIN_SERVER_PORT));
						if (success) {
							AndroidConstants.MAIN_SERVER_IP = MAIN_SERVER_IP;
							AndroidConstants.MAIN_SERVER_PORT = MAIN_SERVER_PORT;
							checkUserDetails();
						} else {
							System.out.println("Redirecting to Config 1");
							go(ConfigTabActivity.class);
						}
					} else {
						System.out.println("Redirecting to Config 2");
						go(ConfigTabActivity.class);
					}
				}
			}
		});

	}

	GPSTracker g = null;

	public void checkUserDetails() {
		g = new GPSTracker(WelcomeActivity.this);
		if (g.canGetLocation) {
			Location l = g.getLocation();
			if (l != null) {
				AndroidConstants.currentLocation = l;
//				toast(l.getLatitude() + " " + l.getLongitude());
				String address = "";
				try {
					String[] tokens = ReverseGeocoder.getLocation(l
							.getLatitude() + "," + l.getLongitude());
					address = tokens[0];
				} catch (Exception e) {
					e.printStackTrace();
				}
				if (address == null || address.equalsIgnoreCase("null")) {
					address = "";
				} else {
					AndroidConstants.CURRENT_LOCATION = address;
//					toast("UPdating Current Location "
//							+ AndroidConstants.CURRENT_LOCATION);
				}
			} else {
//				toast("Unable to get the location at this moment!");
			}
		}

		AndroidConstants.PAGE_2_LOAD = AndroidConstants.MAIN_URL();
		go(WebViewActivity.class);
	}
}
