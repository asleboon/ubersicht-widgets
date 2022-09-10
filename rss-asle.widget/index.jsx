import { css } from "uebersicht";
import * as config from './config.json'
import { parse } from 'rss-to-json'

// link, title, published
// all rss models are the same

export const refreshFrequency = 20000;

export const command = async (dispatch) => {
	// fetch some data based n config.
	const { feeds } = config;

	const feedPromises = feeds.map(async feed => {
		const res = await parse(feed.url);
		return {
			name: feed.name,
			items: res.items.slice(0, feed.max_items),
		}
	})

	const data = await Promise.all(feedPromises)

	dispatch({
		type: "UPDATE_FEED",
		data
	})
}

export const initialState = { feeds: [] };

export const updateState = (event, previousState) => {
	if (event.error) {
		return {
			...previousState, warning: `${event.error}`
		}
	}

	if (event.type === "UPDATE_FEED") {
		return {
			feeds: event.data

		}
	}
	return {
		...previousState
	}
}

 export const className = {
	 top: "60px",
	 left: "850px",
	 width: "400px",
	 backgroundColor: "rgba(0, 0, 0, 0.8)",
	 padding: "5px",
	 boxSizing: "border-box",
	 borderRadius: "5px",
};

const container = css({
  color: "rgba(255, 255, 255)",
  fontFamily: "PT Mono",
  fontSize: "13px",
  textAlign: "left",
  animationName: "tickerv",
  animationDuration: "10s",
  animationIterationCount: "infinite",
  animationTimingFunction: "cubic-bezier(1, 0, .5, 0)"
});

const linksContainer = css({
	display: "flex",
	flexDirection: "column",
	gridGap: "6px"
})

const linkclass = css({
	color: "white",
})

export const render = ({ feeds }) => {
	return (
		<div>
		<div className={container}>
			{feeds.map(feed => {
				return (
					<div className={linksContainer}>
						<h4>{feed.name}</h4>
						{feed.items.map(item => <a className={linkclass} href={item.link} >{item.title}</a>)}
					</div>
				)
			})}
		</div>
		</div>
	)
}
